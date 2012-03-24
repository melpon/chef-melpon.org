{-# LANGUAGE OverloadedStrings #-}

import Control.Exception (bracket)
import Network.Wai (Request(..))
import Network.Wai.Handler.Warp (run)
import qualified Network.HTTP.Conduit as H
import RevProxy (RevProxyRoute(..), revProxyApp)
import System.Posix.Daemonize (daemonize)

main :: IO ()
main = daemonize program

program :: IO ()
program = bracket (H.newManager H.def) H.closeManager $ \manager -> do
  run 80 $ revProxyApp manager proxyRoute
  where
    proxyRoute req = route $ pathInfo req
    route ("yesodbookjp":"test":xs) = Just $ RevProxyRoute "127.0.0.1" xs 4000
    route ("yesodbookjp":xs) = Just $ RevProxyRoute "127.0.0.1" xs 4100
    route ("wandbox":"test":xs) = Just $ RevProxyRoute "127.0.0.1" xs 3000
    route ("wandbox":xs) = Just $ RevProxyRoute "127.0.0.1" xs 3100
    route _ = Nothing

