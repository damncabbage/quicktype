module Main
    ( main
    , renderers
    , urlsFromJsonGrammar
    , intSentinel
    ) where

import Core
import IR
import IRGraph

import Config as Config
import Control.Monad.State (modify)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (decodeJson) as J
import Data.Map as M
import Data.StrMap (StrMap)
import Data.StrMap as SM
import Data.String as String
import Doc as Doc
import IRTypeable (intSentinel) as IRTypeable
import IRTypeable (makeTypes)
import Language.Renderers as Renderers
import Options (OptionValue(..), Option, OptionValues, Options)
import Transformations as T
import UrlGrammar (GrammarMap(..), generate)

-- TODO find a better way to rexport these
intSentinel :: String
intSentinel = IRTypeable.intSentinel

renderers :: Array Doc.Renderer
renderers = Renderers.all

-- FIXME: error handling!
makeOptionValues :: Options -> StrMap String -> OptionValues
makeOptionValues options optionStrings =
    SM.mapWithKey optionValueForOption options
    where
        optionValueForOption :: String -> Option -> OptionValue
        optionValueForOption name { default } =
            case SM.lookup name optionStrings of
            Nothing -> default
            Just s ->
                let l = String.toLower s
                in BooleanValue $ l == "true" || l == "t" || l == "1"

-- json is a Foreign object whose type is defined in /cli/src/Main.d.ts
main :: StrMap String -> Json -> Either Error SourceCode
main optionStrings json = do
    config <- Config.parseConfig json

    let samples = Config.topLevelSamples config
    let schemas = Config.topLevelSchemas config

    renderer <- Config.renderer config

    graph <- normalizeGraphOrder =<< execIR do
        makeTypes samples
        T.replaceSimilarClasses
        T.makeMaps
        modify regatherClassNames

        -- We don't regatherClassNames for schemas
        -- TODO Mark, why not? Tests fail if we do.
        makeTypes schemas
        modify regatherUnionNames

    let optionValues = makeOptionValues renderer.options optionStrings
    pure $ Doc.runRenderer renderer graph optionValues

urlsFromJsonGrammar :: Json -> Either Error (SM.StrMap (Array String))
urlsFromJsonGrammar json = do
    GrammarMap grammarMap <- J.decodeJson json
    pure $ generate <$> grammarMap
