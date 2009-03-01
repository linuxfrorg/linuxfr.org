module TagsHelper

  # <ul>
  # <% tag_cloud(tags, %w(not-popular popular very-popular)) do |tag, klass| %>
  #   <li><%= link_to tag.name, tag_url(tag), :class => klass %>
  # <% end %>
  # </ul>
  def tag_cloud(tags, classes)
    counts = tags.map(&:taggings_count)
    max = counts.max
    min = counts.min
    divisor = ((max - min) / classes.size) + 1

    tags.each do |tag|
      index = (tag.taggings_count - min) / divisor
      yield tag, classes[index]
    end
  end

end
