require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

module Reek
  module Smells

    class NilCheck < SmellDetector

      SMELL_CLASS = 'NilCheck'
      SMELL_SUBCLASS = SMELL_CLASS

      def initialize(source, config = NilCheck.default_config)
        super(source, config)
      end

      def examine_context(ctx)

        call_nodes = CallNodeFinder.new(ctx)
        case_nodes = CaseNodeFinder.new(ctx)
        smelly_calls = call_nodes.smelly
        smelly_cases = case_nodes.smelly

        smelly_nodes = smelly_calls + smelly_cases

        smelly_nodes.map do |node|
          SmellWarning.new(SMELL_CLASS, ctx.full_name, node.line,
                           "performs a nil-check.",
                           @source, SMELL_SUBCLASS )
        end
      end

      class NodeFinder
        SEXP_NIL = Sexp.new(:nil)
        def initialize(ctx, type)
          @nodes = Array(ctx.local_nodes(type))
        end
      end

      class CallNodeFinder < NodeFinder
        def initialize(ctx)
          super(ctx, :call)
        end

        def smelly
          @nodes.select{ |call|
            nil_chk?(call) 
          }
        end

        def nil_chk?(call)
          nilQ_use?(call) || eq_nil_use?(call) 
        end

        def nilQ_use?(call)
          call.last == :nil?
        end

        def eq_nil_use?(call)
          include_eq?(call) && call.include?(SEXP_NIL)
        end

        def include_eq?(call)
          [:==, :===].any? { |operator| call.include?(operator) }
        end
      end

      class CaseNodeFinder < NodeFinder
        CASE_NIL_NODE = Sexp.new(:array, SEXP_NIL)
        def initialize(ctx)
          super(ctx, :when)
          end

        def smelly
          @nodes.select{ |when_node|
            nil_chk?(when_node) 
          }
        end

        def nil_chk?(when_node)
          when_node.include?(CASE_NIL_NODE)
        end
      end

    end
  end
end
