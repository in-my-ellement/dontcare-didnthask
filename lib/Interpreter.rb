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
    def eval_func(t)
        # unwrap it
        expr = t[:expr]

        if t.has_key?(:op)
            # if it contains an infix operator
            name = t[:op].to_sym

        elsif t.has_key(:func)
            # if it contains a function call
   
        end
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

    def run()
        # check for a valid main func
        valid_main = lambda { |d| d[:name] == "main" && d[:arity] == 0 }

        # find the main function declaration
        if !@definitions.any?(valid_main)
            # tell the user to stop posting cringe
            puts "no main function detected. :("
            exit
        end

        # use the main function
        
    end
end

i = Interpreter.new(Parser.new.parse("main = abc(\"haha\") + 3"))
i.find_declarations

puts i.definitions