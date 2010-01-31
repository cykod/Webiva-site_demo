class SiteDemo::PageRenderer < ParagraphRenderer

  features '/site_demo/page_feature'

  paragraph :create_demo

  def create_demo

    
    @available_domain = SiteDemoDomain.domains_available?
    @site_demo_domain = SiteDemoDomain.new(params[:domain])

    if request.post? && params[:domain]
      tpl = SiteDemoTemplate.find_by_id_and_protected_template(params[:domain][:site_demo_template_id],false,params[:domain][:expiration_minutes])
      if tpl
        @site_demo_domain = SiteDemoDomain.new_domain(@site_demo_domain.login_email,tpl.id)
        if @site_demo_domain && @site_demo_domain.errors.length == 0
          paragraph.run_triggered_actions(@site_demo_domain.attributes,'action',myself)
          @created_domain = true
        elsif @site_demo_domain
          paragraph.run_triggered_actions(@site_demo_domain.attributes.merge(:reason => @site_demo_domain.full_messages),'action',myself)
        end
      end
    end

    render_paragraph :feature => :site_demo_page_create_demo
  end


end
