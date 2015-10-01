class CodeMethodDecorator < Draper::Decorator
  delegate_all


  def list_item
     h.content_tag :li, class: "show-list" do
       h.link_to "#{object.name}", h.code_method_path(object) #, class: "btn btn-primary"
     end
  end
  
  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
