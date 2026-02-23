---
layout: default
title: Projects
description: Security engineering projects including AWS infrastructure, SIEM deployment, and container security
---

<section class="posts">
	<article>
		<header>
			<span class="date">Current Project</span>
			<h2><a href="https://github.com/{{ site.author.github }}/aws-portfolio">AWS Security<br />
			Portfolio</a></h2>
		</header>
		<a href="https://github.com/{{ site.author.github }}/aws-portfolio" class="image fit"><img src="{{ '/images/pic02.jpg' | relative_url }}" alt="" /></a>
		<p>Production-grade AWS infrastructure with WAF protection, automated security scanning, and CI/CD pipeline. Demonstrates OWASP Top 10 protection, Infrastructure as Code, and DevSecOps practices.</p>
		<ul class="actions special">
			<li><a href="https://github.com/{{ site.author.github }}/aws-portfolio" class="button">View on GitHub</a></li>
		</ul>
		<ul class="tech-tags">
			<li>AWS WAF</li>
			<li>Terraform</li>
			<li>CloudFront</li>
			<li>GitHub Actions</li>
			<li>TFSec</li>
			<li>Checkov</li>
		</ul>
	</article>
	<article>
		<header>
			<span class="date">Security Engineering</span>
			<h2><a href="{{ '/about' | relative_url }}">CERN<br />
			Infrastructure</a></h2>
		</header>
		<a href="{{ '/about' | relative_url }}" class="image fit"><img src="{{ '/images/pic03.jpg' | relative_url }}" alt="" /></a>
		<p>Implemented security controls and monitoring for large-scale research infrastructure. Focused on network security, threat detection, incident response, and compliance with international security standards.</p>
		<ul class="actions special">
			<li><a href="{{ '/about' | relative_url }}" class="button">Learn More</a></li>
		</ul>
		<ul class="tech-tags">
			<li>Network Security</li>
			<li>SIEM</li>
			<li>Threat Detection</li>
			<li>Compliance</li>
			<li>Incident Response</li>
		</ul>
	</article>
	<article>
		<header>
			<span class="date">Home Lab</span>
			<h2><a href="#">SOC Infrastructure<br />
			& SIEM</a></h2>
		</header>
		<a href="#" class="image fit"><img src="{{ '/images/pic04.jpg' | relative_url }}" alt="" /></a>
		<p>Multi-node Wazuh SIEM deployment with log aggregation, threat detection rules, and automated alerting. Includes WireGuard VPN, automated backups, and security monitoring for home infrastructure.</p>
		<ul class="tech-tags">
			<li>Wazuh</li>
			<li>Docker</li>
			<li>OpenSearch</li>
			<li>WireGuard</li>
			<li>Terraform</li>
		</ul>
	</article>
	<article>
		<header>
			<span class="date">Security Automation</span>
			<h2><a href="#">Pentesting<br />
			Scanner</a></h2>
		</header>
		<a href="#" class="image fit"><img src="{{ '/images/pic05.jpg' | relative_url }}" alt="" /></a>
		<p>Automated security scanning tool combining multiple open-source tools (Nuclei, httpx, Nmap) for vulnerability assessment. Containerized deployment with scheduled scans and HTML report generation.</p>
		<ul class="tech-tags">
			<li>Python</li>
			<li>Docker</li>
			<li>Nuclei</li>
			<li>Nmap</li>
			<li>Security Automation</li>
		</ul>
	</article>
</section>
