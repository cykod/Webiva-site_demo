class SiteDemo::PageController < ParagraphController

  editor_header 'Sitedemo Paragraphs'
  
  editor_for :create_demo, :name => "Create demo", :feature => :site_demo_page_create_demo,
    :triggers => [['Failed Request','failed'], ['Successful Req','action']]

  class CreateDemoOptions < HashModel

  end

end
