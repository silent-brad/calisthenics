{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid (mappend)
import           Hakyll
import           System.Process (readProcess)
import           System.FilePath (replaceExtension, takeBaseName)
import           Control.Monad (liftM)
import           Data.Map (Map)
import qualified Data.Map as M
import           Data.List (stripPrefix)
import           Data.Maybe (fromMaybe)

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

config :: Configuration
config = defaultConfiguration
    { destinationDirectory = "docs"
    , storeDirectory       = "_cache"
    , tmpDirectory         = "_cache/tmp"
    }

--------------------------------------------------------------------------------
-- Pandoc Compiler
--------------------------------------------------------------------------------

pandocTypstCompilerWithMeta :: Compiler (Item String)
pandocTypstCompilerWithMeta = do
    body <- getResourceBody
    let content = itemBody body
    -- Use pandoc to convert from Typst to HTML
    fp <- getResourceFilePath
    html <- unsafeCompiler $ do
        readProcess "pandoc" ["-f", "typst", "-t", "html5", fp] ""
    
    -- Load metadata from .meta file
    let metaPath = replaceExtension fp "meta"
    metaItem <- load (fromFilePath metaPath)
    let metaMap = parseMetadata (itemBody metaItem)
    
    makeItemWithMetadata html metaMap

parseMetadata :: String -> Map String String
parseMetadata content = M.fromList $ map parseLine $ lines content
  where
    parseLine line = case break (== ':') line of
        (key, ':':' ':value) -> (key, value)
        (key, ':':value) -> (key, value)
        _ -> ("", "")

makeItemWithMetadata :: String -> Map String String -> Compiler (Item String)
makeItemWithMetadata html metaMap = do
    identifier <- getUnderlying
    let item = Item identifier html
    return item

--------------------------------------------------------------------------------
-- Main Site Generation
--------------------------------------------------------------------------------

main :: IO ()
main = hakyllWith config $ do
    -- Copy static files
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "fonts/*" $ do
        route   idRoute
        compile copyFileCompiler

    -- Process metadata files
    match "posts/*.meta" $ do
        compile getResourceBody

    -- Create tags
    tags <- buildTags "posts/*.typ" (fromCapture "tags/*.html")

    -- Process Typst blog posts  
    match "posts/*.typ" $ do
        route $ setExtension "html"
        compile $ do
            let postCtxWithTags = tagsField "tags" tags `mappend` postCtx
            pandocTypstCompilerWithMeta
                >>= loadAndApplyTemplate "templates/post.html"    postCtxWithTags
                >>= loadAndApplyTemplate "templates/default.html" postCtxWithTags
                >>= relativizeUrls

    -- Create post list
    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*.typ"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    -- Tags pages
    tagsRules tags $ \tag pattern -> do
        let title = "Posts tagged \"" ++ tag ++ "\""
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll pattern
            let ctx = constField "title" title
                      `mappend` listField "posts" postCtx (return posts)
                      `mappend` defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/tag.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- Index page
    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*.typ"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    -- Static pages (About, Reading List)
    match (fromList ["about.html", "reading-list.html"]) $ do
        route idRoute
        compile $ getResourceBody
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- Templates
    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
-- Contexts
--------------------------------------------------------------------------------

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    tagsFieldFromMetadata `mappend`
    defaultContext

tagsFieldFromMetadata :: Context String
tagsFieldFromMetadata = field "tags" $ \item -> do
    metadata <- getMetadata (itemIdentifier item)
    case lookupString "tags" metadata of
        Just tagsStr -> return $ unwords $ map (\tag -> "<a href=\"/tags/" ++ makeUrl tag ++ "\" class=\"tag\">#" ++ tag ++ "</a>") (splitTags tagsStr)
        Nothing -> return ""
  where
    splitTags tagsStr = map trim $ splitOn ',' tagsStr
    splitOn delim str = case break (== delim) str of
        (chunk, []) -> [chunk]
        (chunk, _:rest) -> chunk : splitOn delim rest
    trim = reverse . dropWhile (== ' ') . reverse . dropWhile (== ' ')
    makeUrl tag = map (\c -> if c == ' ' then '-' else c) tag

tagCtx :: Context String
tagCtx = 
    field "name" (return . itemBody) `mappend`
    field "url" (\item -> return $ map (\c -> if c == ' ' then '-' else c) (itemBody item))
