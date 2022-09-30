port module Runner exposing (browserProgram)

import Spec exposing (Message)


port elmSpecOut : Message -> Cmd msg


port elmSpecIn : (Message -> msg) -> Sub msg


config : Spec.Config msg
config =
    { send = elmSpecOut
    , listen = elmSpecIn
    }


browserProgram =
    Spec.browserProgram config
