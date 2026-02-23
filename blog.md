---
layout: default
title: Blog
description: Security research, tutorials, and insights on cloud security, infrastructure protection, and DevSecOps
---

<header class="major">
	<h1>Security Blog</h1>
	<p>Research, tutorials, and insights on cloud security, infrastructure protection, and DevSecOps</p>
</header>

<section class="posts">
	{% if site.posts.size > 0 %}
		{% for post in site.posts %}
		<article>
			<header>
				<span class="date">{{ post.date | date: "%B %d, %Y" }}</span>
				<h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
			</header>
			{% if post.image %}
			<a href="{{ post.url | relative_url }}" class="image fit"><img src="{{ post.image | relative_url }}" alt="" /></a>
			{% endif %}
			<p>{{ post.excerpt | strip_html | truncatewords: 30 }}</p>
			<ul class="actions special">
				<li><a href="{{ post.url | relative_url }}" class="button">Read More</a></li>
			</ul>
			{% if post.tags %}
			<ul class="tech-tags">
				{% for tag in post.tags %}
				<li>{{ tag }}</li>
				{% endfor %}
			</ul>
			{% endif %}
		</article>
		{% endfor %}
	{% else %}
		<article>
			<header>
				<h2>Coming Soon</h2>
			</header>
			<p>Blog posts on AWS security, SIEM configurations, threat detection, and Infrastructure as Code best practices coming soon!</p>
		</article>
	{% endif %}
</section>
