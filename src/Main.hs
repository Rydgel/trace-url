{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.List
import Control.Lens
import Network.Wreq
import Control.Exception
import Control.Applicative ((<$>))
import qualified Network.HTTP.Client as HT
import qualified Network.HTTP.Types as HT
import qualified Data.ByteString.Char8 as C
import System.Environment


nextLocation :: String -> HT.ResponseHeaders -> Maybe String
nextLocation url xs = (getFullURL . C.unpack) <$> lookup "Location" xs
    where getFullURL x | isInfixOf "http://" x || isInfixOf "https://" x = x
                       | otherwise = (HT.parseUrl url >>= constructURL) ++ x
          constructURL r | HT.secure r = "https://" ++ C.unpack (HT.host r)
                         | otherwise   = "http://" ++ C.unpack (HT.host r)


fetchRedirects :: String -> [String] -> IO [String]
fetchRedirects url xs = do
    let opts = defaults & redirects .~ 0
    try (getWith opts url) >>= check
    where
        check (Left (HT.StatusCodeException s h _))
            | s ^. statusCode `div` 100 == 3 =
                case nextLocation url h of
                    Just location -> fetchRedirects location (xs ++ [url])
                    Nothing -> error "unexpected missing location header"
            | otherwise = do
                print s
                error "unexpected status code"
        check (Left _)  = error "unexpected exception caught"
        check (Right _) = return $ xs ++ [url]


printResult :: [String] -> IO ()
printResult xs = do
    let c = show $ length xs - 1
    putStrLn $ "This URL has " ++ c ++ " redirect hop(s) to the destination."
    putStrLn "Redirect Log:"
    putStrLn $ unlines xs


main :: IO ()
main = do
    argv <- getArgs
    case argv of
        (url:_) -> do
            urls <- fetchRedirects url []
            printResult urls
        _       -> error "bad input, it should be: trace-url <your-url>"

