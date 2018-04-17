--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid ((<>))
import           Hakyll

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "downloads/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "images/**/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "404.html" $ do
        route idRoute
        compile copyFileCompiler

    match (fromList ["about.rst", "contact.markdown", "subscribe.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "notes/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/notes.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts)
                    <> constField "title" ""
                    <> defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "notes.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "notes/*"
            let indexCtx =
                    listField "posts" postCtx (return posts)
                    <> constField "title" ""
                    <> defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls


    create ["rss.xml"] $ do
            route idRoute
            compile $ do
                let feedCtx = postCtx <> bodyField "description"
                loadAllSnapshots "posts/*" "content"
                    >>= recentFirst
                    >>= renderRss feedConfigurationRSS feedCtx


    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx <> bodyField "description"
            posts <- fmap (take 10) . recentFirst =<<
                loadAllSnapshots "posts/*" "content"
            renderAtom feedConfigurationAtom feedCtx posts


    match "templates/*" $ compile templateCompiler

    create ["sitemap.xml"] $ do
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll "posts/*"
                let sitemapCtx =
                      listField "posts" sitemapPostCtx (return posts)
                makeItem ("" :: String)
                    >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx


    match staticFiles $ do
        route idRoute
        compile copyFileCompiler


staticFiles :: Pattern
staticFiles = fromList ["sitemap.xml", "404.html"]

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" <> defaultContext

sitemapPostCtx :: Context String
sitemapPostCtx =
    dateField "date" "%Y-%m-%d"
    <> constField "baseUrl" "http://blog.urbanslug.com"
    <> defaultContext

-- Feed configuration
feedConfigurationRSS :: FeedConfiguration
feedConfigurationRSS = FeedConfiguration
    { feedTitle       = "urbanslug blog - RSS feed"
    , feedDescription = "Programming haskell clojure life"
    , feedAuthorName  = "Njagi Mwaniki"
    , feedAuthorEmail = "njagi@urbanslug.com"
    , feedRoot        = "http://blog.urbanslug.com"
    }

feedConfigurationAtom :: FeedConfiguration
feedConfigurationAtom = FeedConfiguration
    { feedTitle       = "urbanslug blog - Atom feed"
    , feedDescription = "Programming haskell clojure life"
    , feedAuthorName  = "Njagi Mwaniki"
    , feedAuthorEmail = "njagi@urbanslug.com"
    , feedRoot        = "http://blog.urbanslug.com"
    }
