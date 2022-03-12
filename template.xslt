<?xml version="1.0"?>
<!--
  From: https://gist.github.com/wilhelmy/5a59b8eea26974a468c9

  dirlist.xslt - transform nginx's into lighttpd look-alike dirlistings
  I'm currently switching over completely from lighttpd to nginx. If you come
  up with a prettier stylesheet or other improvements, please tell me :)
-->
<!--
   Copyright (c) 2016 by Moritz Wilhelmy <mw@barfooze.de>
   All rights reserved
   Redistribution and use in source and binary forms, with or without
   modification, are permitted providing that the following conditions
   are met:
   1. Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
   THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
   IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
   STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
   IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
-->
<!DOCTYPE fnord [<!ENTITY nbsp "&#160;">]>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:func="http://exslt.org/functions"
  xmlns:str="http://exslt.org/strings"
  version="1.0"
  extension-element-prefixes="func str"
>
  <xsl:output
    method="html"
    html-version="5"
    encoding="utf-8"
    doctype-public=""
  />
  <xsl:strip-space elements="*" />
  <xsl:template name="size">
    <xsl:param name="bytes" />
    <xsl:choose>
      <xsl:when test="$bytes &lt; 1000">
        <xsl:value-of select="$bytes" /> B
      </xsl:when>
      <xsl:when test="$bytes &lt; 1048576">
        <xsl:value-of select="format-number($bytes div 1024, '0.0')" /> KB
      </xsl:when>
      <xsl:when test="$bytes &lt; 1073741824">
        <xsl:value-of select="format-number($bytes div 1048576, '0.0')" /> MB
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="format-number(($bytes div 1073741824), '0.0')" />
        GB
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="timestamp">
    <xsl:param name="iso-timestamp" />
    <xsl:value-of
      select="concat(substring($iso-timestamp, 0, 11), ' ', substring($iso-timestamp, 12, 5))"
    />
  </xsl:template>
  <xsl:template match="directory">
    <tr>
      <td class="icon">
        <svg width="20" height="20">
          <use href="#icon-folder" />
        </svg>
      </td>
      <td class="name">
        <a href="{str:encode-uri(current(),true())}/">
          <xsl:value-of select="." />
        </a>
      </td>
      <td class="time">
        <xsl:call-template name="timestamp">
          <xsl:with-param name="iso-timestamp" select="@mtime" />
        </xsl:call-template>
      </td>
      <td class="size"></td>
    </tr>
  </xsl:template>
  <xsl:template match="file">
    <tr>
      <td class="icon">
        <svg width="20" height="20">
          <use href="#icon-file" />
        </svg>
      </td>
      <td class="name">
        <a href="{str:encode-uri(current(),true())}" target="_blank">
          <xsl:value-of select="." />
        </a>
      </td>
      <td class="time">
        <xsl:call-template name="timestamp">
          <xsl:with-param name="iso-timestamp" select="@mtime" />
        </xsl:call-template>
      </td>
      <td class="size">
        <xsl:call-template name="size">
          <xsl:with-param name="bytes" select="@size" />
        </xsl:call-template>
      </td>
    </tr>
  </xsl:template>
  <xsl:param name="root" />
  <xsl:template match="/">
    <html>
      <xsl:attribute name="lang">zh-cn-hans</xsl:attribute>
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title><xsl:value-of select="$path" /></title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Noto Sans SC",
              "Noto Sans CJK", "MicroSoft YaHei UI", "MicroSoft YaHei",
              "Noto Mono", "Noto Sans", "Segoe UI", Segoe, roboto,
              "Helvetica Neue", Helvetica, Calibri, Arial, monospace;
            max-width: 768px;
            margin: 32px auto;
            overflow: auto;
          }

          ul {
            margin: 0;
            padding: 0;
            flex-wrap: wrap;
            list-style: none;
          }

          li + li::before {
            content: " / ";
            opacity: 0.6;
          }

          li {
            display: inline;
          }

          li,
          li a {
            word-break: break-all;
          }

          a {
            text-decoration: none;
            color: inherit;
          }

          table {
            overflow: hidden;
            width: 100%;
            border-spacing: 0;
          }

          td,
          th {
            padding: 14px;
          }

          .icon {
            width: 0;
            padding-left: 16px;
            padding-right: 0;
          }

          .name {
            text-align: left;
            word-break: break-all;
          }

          .time {
            text-align: center;
            white-space: nowrap;
          }

          .size {
            text-align: right;
            white-space: nowrap;
          }

          td > svg {
            vertical-align: middle;
          }

          tbody tr:nth-child(even) {
            background-color: #eee;
          }

          th {
            background-color: lightgrey;
          }

          @media (min-width: 769px) {
            table {
              border-radius: 8px;
              border: 4px solid lightgrey;
            }
          }

          @media (prefers-color-scheme: dark) and (min-width: 769px) {
            table {
              border-color: #444;
            }
          }

          @media (prefers-color-scheme: dark) {
            html {
              background-color: #222;
              color: #eee;
            }

            tbody tr:nth-child(even) {
              background-color: #333;
            }

            th {
              background-color: #444;
            }
          }
        </style>
      </head>
      <body>
        <table>
          <thead>
            <tr>
              <td colspan="2">
                <ul></ul>
              </td>
              <td colspan="2" class="size">
                <xsl:value-of select="count(//directory)" />
                个目录，<xsl:value-of select="count(//file)" />
                个文件
              </td>
            </tr>
            <tr>
              <th></th>
              <th class="name">文件名</th>
              <th class="time">最近修改时间</th>
              <th class="size">大小</th>
            </tr>
          </thead>
          <tbody>
            <xsl:apply-templates />
          </tbody>
        </table>
        <svg style="display: none">
          <defs>
            <symbol id="icon-file" viewBox="0 0 16 16">
              <path
                fill="currentColor"
                d="M11.724 5.333h-2.391v-2.391zM13.805 5.529l-4.667-4.667c-0.061-0.061-0.135-0.111-0.216-0.145s-0.169-0.051-0.255-0.051h-4.667c-0.552 0-1.053 0.225-1.414 0.586s-0.586 0.862-0.586 1.414v10.667c0 0.552 0.225 1.053 0.586 1.414s0.862 0.586 1.414 0.586h8c0.552 0 1.053-0.225 1.414-0.586s0.586-0.862 0.586-1.414v-7.333c0-0.184-0.075-0.351-0.195-0.471zM8 2v4c0 0.368 0.299 0.667 0.667 0.667h4v6.667c0 0.184-0.074 0.35-0.195 0.471s-0.287 0.195-0.471 0.195h-8c-0.184 0-0.35-0.074-0.471-0.195s-0.195-0.287-0.195-0.471v-10.667c0-0.184 0.074-0.35 0.195-0.471s0.287-0.195 0.471-0.195z"
              />
            </symbol>
            <symbol id="icon-folder" viewBox="0 0 16 16">
              <path
                fill="currentColor"
                d="M15.333 12.667v-7.333c0-0.552-0.225-1.053-0.586-1.414s-0.862-0.586-1.414-0.586h-5.643l-1.135-1.703c-0.121-0.18-0.324-0.297-0.555-0.297h-3.333c-0.552 0-1.053 0.225-1.414 0.586s-0.586 0.862-0.586 1.414v9.333c0 0.552 0.225 1.053 0.586 1.414s0.862 0.586 1.414 0.586h10.667c0.552 0 1.053-0.225 1.414-0.586s0.586-0.862 0.586-1.414zM14 12.667c0 0.184-0.074 0.35-0.195 0.471s-0.287 0.195-0.471 0.195h-10.667c-0.184 0-0.35-0.074-0.471-0.195s-0.195-0.287-0.195-0.471v-9.333c0-0.184 0.074-0.35 0.195-0.471s0.287-0.195 0.471-0.195h2.977l1.135 1.703c0.128 0.191 0.337 0.295 0.555 0.297h6c0.184 0 0.35 0.074 0.471 0.195s0.195 0.287 0.195 0.471z"
              />
            </symbol>
          </defs>
        </svg>

        <script>
          const path = '<xsl:value-of select="$path" />';

          const root = '/<xsl:value-of select="$root" />/'
            .replace(/[\\/]+/, "/")
            .split("/")
            .filter(Boolean)
            .join("/");

          const urls = (
            root ? path.split(root, 2)[1].split("/") : path.split("/")
          ).filter(Boolean);

          const fake = root ? "/" + root : root;

          urls.unshift(fake);

          const sets = urls.map((item, index, array) => ({
            textContent: item === '' ? "根目录" : item,
            href: array.slice(0, index + 1).join("/") + "/",
          }));

          const ele = sets.map(({ textContent, href }) => {
            const a = document.createElement("a");
            a.href = href;
            a.textContent = textContent;
            const li = document.createElement("li");
            li.append(a);
            return li;
          });

          document.body.querySelector("ul").append(...ele);
        </script>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
