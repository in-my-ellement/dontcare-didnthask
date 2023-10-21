require 'parslet'

class Parser < Parslet::Parser 
    root(:expression)

    # whitespace
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }

    # data types
    rule(:int) { 
        match('[0-9]').repeat(1).as(:int) >> 
            space?
    }
    
    rule(:float) {
        (
            match('[0-9]').repeat(1) >>
                match('\.') >>
                match('[0-9]').repeat(1)
        ).as(:float) >> space?
    }

    rule(:string) {
        match('"') >> any.repeat.as(:string) >> match('"') >> space?
    }

    # valid operators
    rule(:operators) { match('[+-/]').as(:op) >> space? }

    # expressions from datatypes and operators
    rule(:expression) { 
        # expression can be just a datatype
        (
            (string | float | int) >>
            # or several joined by operators
            (
                operators >>
                    space? >>
                    expression
            ).maybe
        ).as(:expression)
     }
end

begin 
    p Parser.new.parse("3 + 3.45 + 7.0")
rescue Parslet::ParseFailed => err
    p err.parse_failure_cause.ascii_tree
end
