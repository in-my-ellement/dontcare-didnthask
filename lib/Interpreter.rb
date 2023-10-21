require_relative './Parser.rb'

# basic structure of a definition
$definition = Struct.new(:name, :arity, :body)

class Interpreter 
    # predefined functions and variables
    @@globals = [
        # print output
        $definition.new(
            :print, 1, lambda { |a| puts a }
        ),

        # math operators
        $definition.new(
            :+, 2, lambda { |args| args[args.keys[0]] + args[args.keys[1]] }
        ),
        $definition.new(
            :-, 2, lambda { |args| args[args.keys[0]] - args[args.keys[1]] }
        ),
        $definition.new(
            :*, 2, lambda { |args| args[args.keys[0]] * args[args.keys[1]] }
        ),
        $definition.new(
            :/, 2, lambda { |args| args[args.keys[0]] / args[args.keys[1]] }
        )
    ]

    # getter
    attr_reader :definitions

    def initialize(s) 
        @syntax_tree = s

        # list of functions and variables declared in a syntax tree
        @definitions = Array.new

        # put all the globals into the program scope
        @@globals.each { |g| @definitions << g }
    end 

    # evaluate an expression from the syntax tree
    # this is my child. he has many diseases
    def eval_expr(t)
        # unwrap it
        expr = if t.has_key?(:expr) then t[:expr] else t[t.keys[0]] end

        p expr

        # if it has a function call
        if expr.has_key?(:func)
            # check if the function being used is defined
            name = expr[:func][:name][:identifier]
            names = @definitions.map { |d| d[:name] }

            # if its not defined error out
            if !names.include?(name)
                puts "error: undefined function #{name} being used :("
                exit
            end
        
            # pull args so they can be used to call the function
            args = expr[:func][:args]

            # index in definitions of the function
            index = names.find { |a| a == name }
            
            # call the function if the function
            return @definitions[index][:body].call if @definitions[index][:body].class == Proc

            # otherwise parse the underlying expression
            return eval_expr(@definitions[index][:body])
        end

        # if it uses an infix operator
        if expr.has_key?(:op)
            # left operand
            left = expr[expr.keys[0]].str

            # right operand
            right = expr[expr.keys[-1]]

            puts right

            # match the operator to the appropriate function definition
            case expr[:op]
                when :+
                    return left + eval_expr(right)
                when :-
                    return left - eval_expr(right)
                when :*
                    return left * eval_expr(right)
                when :/
                    return left / eval_expr(right)
            end
        end

        # if it reaches this point its just an expr literal
        # TODO !!!!
        return expr[expr.keys[0]]
    end

    # first pass: read all declarations
    def find_declarations()
        @syntax_tree.each do |declaration| 
            # function name
            name = declaration[:name][:identifier]

            # if there are no args, arity is 0
            arity = if declaration.has_key?(:args) then declaration[:args].length else 0 end

            # convert function body from a tree into a function
            body = declaration[:body]

            # store
            @definitions.append($definition.new(name, arity, body))
        end
    end

    # pretty print declarations so i have smth to show off
    def print_declarations()
        @definitions.each do |d|
            # where it came from
            source = if d[:body].class == Proc then "the interpreter" else "the program" end

            # print info
            puts "\t#{d[:name]} takes #{d[:arity]} arguments and is defined from #{source}"
        end
    end

    def run()
        # check for a valid main func
        valid_main = lambda { |d| d[:name] == "main" && d[:arity] == 0 }

        # find the main function declaration
        if !@definitions.any?(valid_main)
            # tell the user to stop posting cringe
            puts "error: no main function detected. :("
            exit
        end

        # use the main function
        puts eval_expr(@definitions[-1][:body])
    end
end