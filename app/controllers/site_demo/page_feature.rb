class SiteDemo::PageFeature < ParagraphFeature


  feature :site_demo_page_create_demo, :default_feature => <<-FEATURE
    <cms:available_domain>
       <cms:errors/>
       <table>
       <cms:template>
        <tr>
         <td><cms:image/></td>
         <td><cms:item/><br/>
             <cms:description/>
         </td>
       </tr>
       </cms:template>
       </table>
       <cms:captcha/>
       <cms:submit>Request Demo</cms:submit>
    </cms:available_domain>
    <cms:limit_reached>
        There are currently no demo domains available, please try back later.
    </cms:limit_reached>
    <cms:activating_domain>
        Please wait the system is launching the demo site...
    </cms:activating_domain>
    <cms:activated_domain>
        You can access the demo at by clicking on the following link:

        <cms:link>Access Demo</cms:link><br/>
         (Please note this is a one-time link - you'll need to launch a new demo to access it again)
    </cms:activated_domain>
  FEATURE
  

  def site_demo_page_create_demo_feature(data)
    webiva_feature(:site_demo_page_create_demo,data) do |c|
      c.form_for_tag('available_domain','domain') { |t| (data[:available_domain] && !data[:created_domain] && !data[:activated_domain]) ? data[:site_demo_domain] : nil }

        c.captcha_tag('available_domain:captcha') { |t| data[:captcha]}

        c.form_error_tag('available_domain:errors')
        c.loop_tag('available_domain:template') {  |t| data[:demo_templates] }
        c.image_tag('available_domain:template:image') { |t| t.locals.template.image }
        c.h_tag('available_domain:template:description') {  |t| t.locals.template.description }
        c.define_tag('available_domain:template:item') do |t|
          "<label for='#{ "domain_site_template_template_id_#{t.locals.template.id.to_s}" }'>" +
          radio_button_tag('domain[site_demo_template_id]',t.locals.template.id.to_s,data[:site_demo_domain].site_demo_template_id == t.locals.template.id, :id => "domain_site_template_template_id_#{t.locals.template.id.to_s}") +
           "#{t.locals.template.name}</label>"
        end

        c.button_tag('available_domain:submit',:default_value => 'Submit')
      c.expansion_tag('limit_reached') {  |t| !data[:available_domain] && !data[:created_domain] && !data[:activated_domain] }
      c.expansion_tag('activating_domain') { |t| data[:created_domain] }
      c.expansion_tag('activated_domain') { |t| data[:activated_domain] && !data[:created_domain] }
      c.link_tag('activated_domain:') { |t| data[:domain_link]}
    end
  end


end
