{-# LANGUAGE OverloadedStrings #-}

import Control.Exception (bracket)
import Network.Wai (Request(..))
import Network.Wai.Handler.Warp (run)
import qualified Network.HTTP.Conduit as H
import RevProxy (RevProxyRoute(..), revProxyApp)

main :: IO ()
main = bracket (H.newManager H.def) H.closeManager $ \manager -> do
  run 80 $ revProxyApp manager proxyRoute
  where
    proxyRoute req = route $ pathInfo req
    route ("yesodbookjp":xs) = Just $ RevProxyRoute "melpon.org" xs 4100
    route ("wandbox":xs) = Just $ RevProxyRoute "melpon.org" xs 3100
    route _ = Nothing

