Dzl::Examples::MultiFile::App.router do
  get '/two' do
    handle do
      'two'
    end
  end

  get '/import' do
    import_pblock :import
  end
end