# frozen_string_literal: true

class SitesController < ApplicationController
    # set site controller layout
    layout 'site'

    # disable the CSRF protection
    skip_before_action :verify_authenticity_token    

    # Index action
    def index
        @params = params
        # render :json => @params
        # render "index.html.erb"
    end

    # Test action
    def test
        @params = params
        render :json => @params
    end

end