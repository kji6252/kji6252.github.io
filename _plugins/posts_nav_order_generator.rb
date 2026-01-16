# Posts Nav Order Generator
# 블로그 포스트의 date를 기준으로 nav_order를 자동 계산하여 최신순 정렬
# 최신 포스트가 nav_order=1, 그 다음이 nav_order=2, ...
module Jekyll
  class PostsNavOrderGenerator < Generator
    safe true
    priority :low

    def generate(site)
      # 날짜 기준 내림차순 정렬 (최신이 먼저)
      posts = site.posts.docs.sort_by { |p| p.data['date'] }.reverse

      posts.each_with_index do |post, index|
        # 이미 nav_order가 수동으로 지정된 경우 건너뜀
        next if post.data.key?('nav_order')

        # date가 있는 경우에만 nav_order 계산
        if post.data.key?('date')
          # 최신 포스트가 1, 그 다음이 2, ...
          nav_order = index + 1
          post.data['nav_order'] = nav_order

          # 디버깅용 로그
          puts "PostNavOrder: #{post.data['title']} -> nav_order=#{nav_order}"
        end
      end
    end
  end
end
