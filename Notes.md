# Notes

## Parsing Gherkin

Gherkin is quite straightforward to understand but has some challenges in parsing.

My first problem was of course that I am not fluent enough in elm/parser. 

The first thing that took me a while was to parse lines that are "other". To read a description that are several lines and has no ending other than another keyword comes up. Sounds easy but in practice, it is in the details the real hurdles are.

### Baseline 1

I have a parser that can understand a feature with a number of scenarios. That is enough to move on to the next part of a skeleton that includes taking a limited specification, a limited fixture and test against an implementation.

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
