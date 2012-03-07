
desc 'Generate documentation templates'
task :diesel_doc do
  ObjectSpace.each_object(Diesel::DSLSubjects::Router) {|obj| obj.to_docs}
end