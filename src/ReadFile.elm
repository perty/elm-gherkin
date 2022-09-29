module ReadFile exposing (program)

import Gherkin exposing (FeatureFile)
import GherkinParser
import Posix.IO as IO exposing (IO, Process)
import Posix.IO.File as File
import Posix.IO.Process as Proc


program : Process -> IO ()
program process =
    case process.argv of
        [ _, filename ] ->
            IO.do
                (File.contentsOf filename
                    |> IO.exitOnError identity
                )
            <|
                \content -> parse content

        _ ->
            Proc.logErr "Usage: elm-cli <program> file\n"


parse : String -> IO ()
parse contents =
    case GherkinParser.parse contents of
        Ok value ->
            Proc.print (Debug.toString value)

        Err error ->
            Proc.print ("Error" ++ Debug.toString error)
