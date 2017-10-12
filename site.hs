#! /usr/bin/env nix-shell
#! nix-shell -i runhaskell
#! nix-shell -p 'haskellPackages.ghcWithPackages (p: [ p.hakyll p.filepath ])'

--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
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

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archive"             `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" ""                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    create ["rss.xml"] $ do
            route idRoute
            compile $ do
                let feedCtx = postCtx `mappend` bodyField "description"
                loadAllSnapshots "posts/*" "content"
                    >>= recentFirst
                    >>= renderRss feedConfigurationRSS feedCtx


    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx `mappend` bodyField "description"
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
                makeItem ""
                    >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx


    match staticFiles $ do
        route idRoute
        compile copyFileCompiler


staticFiles :: Pattern
staticFiles = fromList ["sitemap.xml", "404.html"]

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

sitemapPostCtx :: Context String
sitemapPostCtx =
    dateField "date" "%Y-%m-%d" `mappend`
    constField "baseUrl" "http://blog.urbanslug.com" `mappend`
    defaultContext

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
