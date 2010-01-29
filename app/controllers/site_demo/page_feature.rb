class SiteDemo::PageFeature < ParagraphFeature


  feature :site_demo_page_create_demo, :default_feature => <<-FEATURE
    <cms:available_domain>
       <cms:errors/>
       Your Email: <cms:email/> (You will be sent an email with login instructions)<br/>
       Template to use: <cms:templates/>
       <cms:submit>Request Demo</cms:submit>
    </cms:available_domain>
    <cms:limit_reached>
        There are currently no demo domains available, please try back later.
    </cms:limit_reached>
    <cms:activated_domain>
        Please give the system gnomes a minute or two to pull the demo
        from storage and speak the appropriate incanations. 
        Once that's done, you will be sent an email with login instructions
        to the demo.
    </cms:activated_domain>
  FEATURE
  

  def site_demo_page_create_demo_feature(data)
    webiva_feature(:site_demo_page_create_demo,data) do |c|
      c.form_for_tag('available_domain','domain') { |t| (data[:available_domain] && !data[:created_domain]) ? data[:site_demo_domain] : nil }
        c.form_error_tag('available_domain:errors')
        c.field_tag('available_domain:email',:field => 'login_email')
        c.field_tag('available_domain:templates',:control => 'select',:field => 'site_demo_template_id') { |t|  SiteDemoTemplate.select_options(:conditions => {  :protected_template => false},:order => 'weight') }
        c.button_tag('available_domain:submit',:default_value => 'Submit')
      c.expansion_tag('limit_reached') {  |t| !data[:available_domain] && !data[:created_domain]}
      c.expansion_tag('activated_domain') { |t| data[:created_domain] }
    end
  end


end
