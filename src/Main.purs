module Main where

import Prelude

import Control.Monad.Except (ExceptT)
import Data.Either (Either(..))
import Data.Maybe (Maybe(Nothing), fromMaybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Console (error, log) as Console
import Effect.Exception (message)
import Node.HTTP (createServer, listen)
import Node.Process (getEnv)
import Nodetrout (HTTPError, serve')
import Type.Data.Row (RProxy(..))
import Type.Proxy (Proxy(..))
import Type.Trout (type (:<|>), type (:=), type (:>), type (:/), QueryParam, Resource)
import Type.Trout.ContentType.JSON (JSON)
import Type.Trout.Method (Get)
import TypedEnv (type (<:), envErrorMessage)
import TypedEnv (fromEnv) as TypedEnv

type API =
       "hello" := Resource (Get String JSON)
  :<|> "echo" := "echo" :/ QueryParam "message" String :> Resource (Get String JSON)

handlers ::
  { hello :: { "GET" :: ExceptT HTTPError Aff String }
  , echo :: Maybe String -> { "GET" :: ExceptT HTTPError Aff String }
  }
handlers =
  { hello: { "GET": pure "Hello World" }
  , echo: \m -> { "GET": pure $ fromMaybe "" m }
  }

api :: Proxy API
api = Proxy

type Config = ( port :: Int <: "PORT" )

main :: Effect Unit
main = do
  env <- TypedEnv.fromEnv (RProxy :: RProxy Config) <$> getEnv
  case env of
    Left error ->
      Console.error $ envErrorMessage error
    Right { port } -> do
      server <- createServer $ serve' api handlers (Console.error <<< message)
      listen server { hostname: "0.0.0.0", port, backlog: Nothing } $ Console.log ("Listening on " <> show port <> "...")
