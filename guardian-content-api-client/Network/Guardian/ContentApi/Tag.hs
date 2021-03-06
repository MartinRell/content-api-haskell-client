{-#LANGUAGE OverloadedStrings #-}

module Network.Guardian.ContentApi.Tag where

import Network.Guardian.ContentApi.Reference
import Network.Guardian.ContentApi.Section
import Network.Guardian.ContentApi.URL

import Control.Monad (mzero)
import Control.Applicative

import Data.Aeson
import Data.Text (Text)

newtype TagId = TagId { unTagId :: Text } deriving (Show)

-- Currently just copying the Scala client's implementation. It would certainly 
-- be nicer to clean this up a lot. Byline images, for example, are only really 
-- relevant for contributors. We could possibly do away with 'tagType' here and 
-- have proper disjoint types.
data Tag = Tag {
    tagId :: TagId
  , tagType :: Text
  , section :: Maybe Section
  , webTitle :: Text
  , webUrl :: URL 
  , apiUrl :: URL
  , references :: Maybe [Reference]
  , bio :: Maybe Text
  , bylineImageUrl :: Maybe URL 
  , largeBylineImageUrl :: Maybe URL
  } deriving (Show)

instance FromJSON Tag where
  parseJSON (Object v) = do
    tagId <- v .: "id"
    tagType <- v .: "type"
    sectionId <- v .:? "sectionId"
    sectionName <- v .:? "sectionName"
    webTitle <- v .: "webTitle"
    webUrl <- v .: "webUrl"
    apiUrl <- v .: "apiUrl"
    references <- v .:? "references"
    bio <- v .:? "bio"
    bylineImageUrl <- v .:? "bylineImageUrl"
    largeBylineImageUrl <- v .:? "bylineLargeImageUrl"
    return $ Tag (TagId tagId) tagType (Section <$> sectionId <*> sectionName) 
      webTitle (URL webUrl) (URL apiUrl) references bio (URL <$> bylineImageUrl)
      (URL <$> largeBylineImageUrl)

  parseJSON _ = mzero

-- TODO: add all fields here http://explorer.content.guardianapis.com/#/tags?q=video
data TagSearchQuery = TagSearchQuery {
    tsQueryText :: Maybe Text
  , tsSection :: [Text]
  , tsTagType :: Maybe Text
  } deriving (Show)

data TagSearchResult = TagSearchResult {
    status :: Text
  , totalResults :: Int
  , startIndex :: Int
  , pageSize :: Int 
  , currentPage :: Int 
  , pages :: Int 
  , results :: [Tag]  
  } deriving (Show)

instance FromJSON TagSearchResult where
  parseJSON (Object v) = do
    r <- v .: "response"
    status <- r .: "status"
    totalResults <- r .: "total"
    startIndex <- r .: "startIndex"
    pageSize <- r .: "pageSize"
    currentPage <- r .: "currentPage"
    pages <- r .: "pages"
    results <- r .: "results"
    return $ TagSearchResult status totalResults startIndex pageSize 
      currentPage pages results
      
  parseJSON _ = mzero
