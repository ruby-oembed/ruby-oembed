module OEmbed
  module Tasks
    begin
      require 'yard'
      require 'yard/rake/yardoc_task'
      require 'bluecloth'
      
      class Rdoc < Task
        def active?
          true
        end

        def define
          desc "Generate documentation using YARD"
          task :rdoc => ['doc:generate']
          #task :rdoc do
          #  Gem::DocManager.new(spec).extend(Extensions::DocManager).generate_rdoc
          #  Shoe.browse('rdoc/index.html')
          #end
        end
      end
    rescue LoadError
      puts 'yard not installed'
    end
    
  end
end