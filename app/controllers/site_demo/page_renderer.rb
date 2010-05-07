class SiteDemo::PageRenderer < ParagraphRenderer

  features '/site_demo/page_feature'

  paragraph :create_demo

  def create_demo

    
    @available_domain = SiteDemoDomain.domains_available?
    @site_demo_domain = SiteDemoDomain.new(params[:domain])
    @demo_templates = SiteDemoTemplate.find(:all,:conditions => {  :protected_template => false},:order => 'weight')
    @site_demo_domain.site_demo_template_id = @demo_templates[0].id if  @site_demo_domain.site_demo_template_id.blank?

    @captcha = WebivaCaptcha.new(self)

    if request.post? && params[:domain]
      @captcha.validate_object(@site_demo_domain) 
      tpl = SiteDemoTemplate.find_by_id_and_protected_template(params[:domain][:site_demo_template_id],false,params[:domain][:expiration_minutes])
      if @site_demo_domain.valid? && tpl
        @site_demo_domain = SiteDemoDomain.new_domain(tpl.id)
        if @site_demo_domain && @site_demo_domain.errors.length == 0
          paragraph.run_triggered_actions(@site_demo_domain.attributes,'action',nil)
          @created_domain = true

          headers['Refresh'] = '5; URL=' + site_node.node_path + "?activated=1"

          session[:site_demo_activated_domain] = @site_demo_domain.id
          
        elsif @site_demo_domain
          paragraph.run_triggered_actions(@site_demo_domain.attributes.merge(:reason => @site_demo_domain.errors.full_messages),'failed',nil)
        end
      end
    end
    if params[:activated] 
      @activated_domain = SiteDemoDomain.find_by_id( session[:site_demo_activated_domain])
      if @activated_domain
        if @activated_domain.active? && @activated_domain.expires_at
          session[:site_demo_activated_domain] = nil
          @editor_login = EditorLogin.find_by_email_and_domain_id('demo@webiva.org',@activated_domain.domain_id)
          if @editor_login
            @domain_link = "http://#{@activated_domain.name}/website?login_hash=" + @editor_login.login_hash
          else
            @activated_domain = nil
          end
        else
          @created_domain = true
          headers['Refresh'] = '5; URL=' + site_node.node_path + "?activated=1"
        end
      end
                                                     
    end

    render_paragraph :feature => :site_demo_page_create_demo
  end


end
