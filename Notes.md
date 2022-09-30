# Notes

## Parsing Gherkin

Gherkin is quite straightforward to understand but has some challenges in parsing.

My first problem was of course that I am not fluent enough in elm/parser. 

The first thing that took me a while was to parse lines that are "other". To read a description that are several lines and has no ending other than another keyword comes up. Sounds easy but in practice, it is in the details the real hurdles are.

### Baseline 1

I have a parser that can understand a feature with a number of scenarios. That is enough to move on to the next part of a skeleton that includes taking a limited specification, a limited fixture and test against an implementation.

#### Alternative approach

It struck me that it could possibly easier is to parse each line separately instead of trying to do the whole file. The result will be on a lower level, closer to how the input file is structured. It remains to see which output is the easiest to use.

### Upcoming: Find fixtures

After parsing Gherkin, the next thing could be to connect steps with fixtures, sometimes called step definitions. First step is no fancy, just compare strings as they are and find the fixtures. In that area, matching fixtures using an expression, would be next. Example "Issues command "E" 12 4" should match "Issues command {string} {int} {int}".

### Upcoming: Generate output

Using the parsed Gherkin, we want to create an output. Like:

```
suite : Test
suite =
    describe "Feature: Navigation"
        ([ Spec.scenario "Crashing into a star while moving"
            (Spec.given Fixture.init
                |> Spec.when "a quadrant at 3,5"
                    Fixture.lookup "a quadrant at 3,5"
                |> Spec.when "starship is located at sector 3,5"
                    Fixture.lookup "starship is located at sector 3,5"
```

## Goal

I would like to have a tool where the specification is completely free of implementation details, all should be in a fixture. Like Cucumber. That way, a specification can be used for implementations in different languages.

````mermaid
classDiagram
    Implementation<..Fixture
    AST<..GherkinParser
    Specification<..GherkinParser
    AST<..SpecRunner
    Fixture<..SpecRunner
````

The parser parses the specification, executes the steps in the scenarios.
For each step, the fixture is examined to find the function to call.
_How to do that?_ Experiment, a structure where I can look up a function and
call it.

### Options

#### elm-spec

Translating to elm-spec is the most promising next step. It has a lot going for it. It runs the implementation in a JSDOM headless browser. Many problems have been solved, like checking HTTP calls.

I would have used it if it wasn't for it's specification API. It is not Gherkin and it is specific to Elm, which defies the goal of implementations in different languages.

#### elm-program-test

Tries to solve the same problem, running the whole Elm program in a test. It has the problem of Cmd not being inspectable and therefore you need to rewrite your update function using the Effect pattern. 

#### elm-test

This is made for unit tests and while I am mostly interested in testing business logic, it feels limited.

#### Roll my own runner

Guaranteed to be a lot of work and will probably result in a subset of elm-spec. Which may be also an option, a fork of `elm-spec` to see if the one thing I don't appreciate can be fixed, the test DSL.
