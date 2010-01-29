class SiteDemo::PageController < ParagraphController

  editor_header 'Sitedemo Paragraphs'
  
  editor_for :create_demo, :name => "Create demo", :feature => :site_demo_page_create_demo

  class CreateDemoOptions < HashModel

  end

end
