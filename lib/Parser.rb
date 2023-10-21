require 'parslet'

class Parser < Parslet::Parser 
    root(:program)

    # whitespace
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }

    rule(:newline) { match('\n').repeat(1) }
    rule(:newline?) { newline.maybe }

    # integers
    rule(:int) { 
        match('[0-9]').repeat(1).as(:int) >> 
        space?
    }
    
    # decimals
    rule(:dec) {
        (
            match('[0-9]').repeat(1) >>
            match('\.') >>
            match('[0-9]').repeat(1)
        ).as(:dec) >> space?
    }

    # strings of characters
    rule(:string) {
        str('"') >> (
            str('\\') >> any | str('"').absent? >> any
        ).repeat.as(:string) >> str('"') >> space?
    }

    # variable/function names
    rule(:identifier) {
        match('[[:alnum:]]').repeat(1).as(:identifier) >> space?
    }

    # valid operators
    rule(:operators) { match('[+-/\*]').as(:op) >> space? }

    # expressions from datatypes and operators
    rule(:expression) { 
        # expression can be just one datatype
        (
            (string | dec | int | identifier) >>
            # or several joined by operators
            (
                operators >>
                space? >>
                expression
            ).maybe
        ).as(:expr)
    }

    # declaration
    rule(:declaration) {
        (
            # function name
            identifier.as(:name) >>
            space? >>

            # function args
            (
                # parenthesis around arg list
                str("(") >>
                (identifier >> space?).repeat.as(:args) >>
                str(")") >>
                space?
            ).maybe >>
            space? >>

            str('=') >>
            space? >>

            expression.as(:body)
        )
    }

    # program is a bunch of declarations
    rule(:program) {
        (
            declaration >>
            newline?
        ).repeat(1)
    }
end

begin 
    p Parser.new.parse('add3(n) = n + 3')
rescue Parslet::ParseFailed => err
    puts err.parse_failure_cause.ascii_tree
end
