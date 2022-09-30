module Fixture exposing (initScenario, lookup)

import Spec.Setup as Setup


initScenario init view update =
    Setup.init (init ())
        |> Setup.withView view
        |> Setup.withUpdate update


lookup : String -> List x
lookup string =
    []
