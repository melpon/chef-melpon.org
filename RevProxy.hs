{-# LANGUAGE OverloadedStrings #-}

module RevProxy (
    RevProxyRoute (..)
  , RevProxyRouteConv
  , revProxyApp
) where

import Control.Applicative ((<$>))
import Control.Exception (SomeException)
import Control.Exception.Lifted (catch)
import qualified Data.ByteString.Char8 as BS
import Data.Conduit (Flush(..), ResourceT, Source)
import Data.Int (Int64)
import Data.Maybe (fromMaybe)
import qualified Network.HTTP.Conduit as H
import Network.HTTP.Types (badGateway502)
import Network.Wai (Request(..), Response(..), Application)
import Prelude hiding (catch)
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC
import qualified Data.Text as T
import qualified Blaze.ByteString.Builder as BB (fromByteString)

data RevProxyRoute = RevProxyRoute {
    revProxyDomain :: B.ByteString
  , revProxyDst :: [T.Text]
  , revProxyPort :: Int
  }

type RevProxyRouteConv = Request -> Maybe RevProxyRoute

toHTTPRequest :: Request -> RevProxyRoute -> Int64 -> H.Request IO
toHTTPRequest req route len = H.def {
    H.host = revProxyDomain route
  , H.port = revProxyPort route
  , H.secure = isSecure req
  , H.requestHeaders = requestHeaders req
  , H.path = path
  , H.queryString = rawQueryString req
  , H.requestBody = getBody req len
  , H.method = requestMethod req
  , H.proxy = Nothing
  , H.rawBody = False
  , H.decompress = H.alwaysDecompress
  , H.checkStatus = \_ _ -> Nothing
  , H.redirectCount = 0
  }
  where
    path = BC.concat $ map (BC.cons '/') $ map (BC.pack . T.unpack) $ revProxyDst route

getBody :: Request -> Int64 -> H.RequestBody IO
getBody req len = H.RequestBodySource len (toBodySource req)
  where
    toBodySource = (BB.fromByteString <$>) . requestBody

getLen :: Request -> Maybe Int64
getLen req = do
    len' <- lookup "content-length" $ requestHeaders req
    case reads $ BS.unpack len' of
        [] -> Nothing
        (i, _):_ -> Just i

{-|
  Relaying any requests as reverse proxy.
-}

revProxyApp :: H.Manager -> RevProxyRouteConv -> Application
revProxyApp mgr routeConv req = go $ routeConv req
  where
    go Nothing = badGateway req undefined
    go (Just route) = revProxyApp' mgr route req
                       `catch` badGateway req

revProxyApp' :: H.Manager -> RevProxyRoute -> Application
revProxyApp' mgr route req = do
    let mlen = getLen req
        len = fromMaybe 0 mlen
        httpReq = toHTTPRequest req route len
    H.Response status hdr downbody <- http httpReq mgr
    return $ ResponseSource status hdr (Chunk . BB.fromByteString <$> downbody)

type Resp = ResourceT IO (H.Response (Source IO BS.ByteString))

http :: H.Request IO -> H.Manager -> Resp
http req mgr = H.http req mgr

badGateway :: Request -> SomeException -> ResourceT IO Response
badGateway _ _ = do
    return $ ResponseBuilder st hdr bdy
  where
    hdr = []
    bdy = BB.fromByteString "Bad Gateway\r\n"
    st = badGateway502

