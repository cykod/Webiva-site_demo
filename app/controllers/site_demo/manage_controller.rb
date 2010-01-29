
class SiteDemo::ManageController < ModuleController

  component_info 'SiteDemo'

  permit "site_demo_manage"
  
  cms_admin_paths "content",
     "Site Demos" => { :action => 'index'},
     "Templates" => { :action => 'templates' }
  

  active_table :demo_domains_table, SiteDemoDomain, 
  [ :check, :name, hdr(:boolean,:active), :activated_at,:expires_at, :template_name,
    :login_email, :login_password ]                                                    

  def display_demo_domains_table(display=true)

    active_table_action("demo") do |act,dids|
      if act == 'expire'
        SiteDemoDomain.find(dids).each {  |dmn|  dmn.update_attributes(:expires_at => Time.now - 2.minutes)}
      else
        adjustment =  case act
                      when 'extend10': 10.minutes
                      when 'extend60': 60.minutes
                      when 'extendday':1.days
                      end
        SiteDemoDomain.find(dids).each {  |dmn|  dmn.update_attributes(:expires_at => dmn.expires_at + adjustment)}
      end
    end

    @tbl = demo_domains_table_generate params, { :order => 'activated_at DESC' }

    render :partial => 'demo_domains_table' if display
  end

  def index
    cms_page_path ["Content"], "Site Demos"

    display_demo_domains_table(false)
  end

  def edit

    @domain = SiteDemoDomain.find_by_id(params[:path][0])
  end

  def create
    cms_page_path ["Content", "Site Demos"], "Add a new demo"

    @site_demo_domain = SiteDemoDomain.new(:expiration_minutes =>  SiteDemo::AdminController.module_options.time_limit) 

    if request.post? && params[:domain]
      if params[:commit]
        tpl = SiteDemoTemplate.find(params[:domain][:site_demo_template_id])
        @site_demo_domain = SiteDemoDomain.new_domain(params[:domain][:login_email],tpl.id,params[:domain][:expiration_minutes].to_i)
        if @site_demo_domain && @site_demo_domain.errors.length == 0
          flash[:notice] = "Activated domain #{@site_demo_domain.name} for #{@site_demo_domain.login_email}"
          redirect_to :action => 'index'
        end
      else
          redirect_to :action => 'index'
      end
    end
  end

  active_table :demo_templates_table, SiteDemoTemplate,
  [ :check, hdr(:boolean,:protected,:label => 'P'), :name, :directory, :created_at]

  def display_demo_templates_table(display=true)
    @tbl = demo_templates_table_generate(params, { :order => "created_at DESC" })

    render :partial => 'demo_templates_table' if display

  end

  def templates
    cms_page_path ["Content", "Site Demos"], "Templates"

    display_demo_templates_table(false)
  end

  def edit_template
    cms_page_path ["Content", "Site Demos", "Templates"], "Edit Template"
    
    @tpl = SiteDemoTemplate.find_by_id(params[:path][0]) || SiteDemoTemplate.new

    if request.post? && params[:tpl]
      if params[:commit] 
        if @tpl.update_attributes(params[:tpl])
          flash[:notice] = 'Saved Template'
          redirect_to :action => 'templates'
        end
      else
        redirect_to :action => 'templates'
      end
    end
  end
end
