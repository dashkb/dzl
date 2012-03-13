
desc 'Generate documentation templates'
task :distil_doc do
  ObjectSpace.each_object(Distil::DSLSubjects::Router) {|obj| obj.to_docs}
end