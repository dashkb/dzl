
desc 'Generate documentation templates'
task :dzl_doc do
  ObjectSpace.each_object(Dzl::DSLSubjects::Router) {|obj| obj.to_docs}
end