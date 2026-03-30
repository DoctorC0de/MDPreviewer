use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use pulldown_cmark::{html, Event, Options, Parser, Tag, CodeBlockKind, TagEnd};
use syntect::highlighting::ThemeSet;
use syntect::html::highlighted_html_for_string;
use syntect::parsing::SyntaxSet;

#[no_mangle]
pub extern "C" fn mdpreviewer_render(
    markdown_ptr: *const c_char,
    is_truncated: bool,
) -> *mut c_char {
    if markdown_ptr.is_null() {
        return std::ptr::null_mut();
    }

    let c_str = unsafe { CStr::from_ptr(markdown_ptr) };
    let markdown = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let mut options = Options::empty();
    options.insert(Options::ENABLE_STRIKETHROUGH);
    options.insert(Options::ENABLE_TABLES);
    options.insert(Options::ENABLE_FOOTNOTES);
    options.insert(Options::ENABLE_TASKLISTS);
    options.insert(Options::ENABLE_SMART_PUNCTUATION);

    let ps = SyntaxSet::load_defaults_newlines();
    let ts = ThemeSet::load_defaults();
    let theme = &ts.themes["InspiredGitHub"]; // Modern clean theme

    let parser = Parser::new_ext(markdown, options);
    let mut html_output = String::new();
    let mut in_code_block = false;
    let mut code_content = String::new();
    let mut current_lang = String::new();

    for event in parser {
        match event {
            Event::Start(Tag::CodeBlock(CodeBlockKind::Fenced(lang))) => {
                in_code_block = true;
                current_lang = lang.to_string();
                code_content.clear();
            }
            Event::End(TagEnd::CodeBlock) => {
                if in_code_block {
                    let syntax = ps.find_syntax_by_extension(&current_lang)
                        .unwrap_or_else(|| ps.find_syntax_plain_text());
                    let highlighted = highlighted_html_for_string(&code_content, &ps, syntax, theme);
                    match highlighted {
                        Ok(h) => html_output.push_str(&h),
                        Err(_) => {
                            html_output.push_str("<pre><code>");
                            html_output.push_str(&code_content);
                            html_output.push_str("</code></pre>");
                        }
                    }
                    in_code_block = false;
                }
            }
            Event::Text(text) => {
                if in_code_block {
                    code_content.push_str(&text);
                } else {
                    html_output.push_str(&text);
                }
            }
            _ => {
                let mut temp = String::new();
                let single_event = std::iter::once(event);
                html::push_html(&mut temp, single_event);
                html_output.push_str(&temp);
            }
        }
    }

    let final_html = format!(
        r#"<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        :root {{
            --bg-color: #ffffff;
            --text-color: #1f2328;
            --link-color: #0969da;
            --border-color: #d0d7de;
            --code-bg: #f6f8fa;
            --blockquote-color: #6e7781;
            --h1-color: #1f2328;
        }}
        @media (prefers-color-scheme: dark) {{
            :root {{
                --bg-color: #0d1117;
                --text-color: #e6edf3;
                --link-color: #4493f8;
                --border-color: #30363d;
                --code-bg: #161b22;
                --blockquote-color: #8b949e;
                --h1-color: #e6edf3;
            }}
        }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            line-height: 1.6;
            word-wrap: break-word;
            padding: 40px;
            max-width: 850px;
            margin: 0 auto;
            background-color: var(--bg-color);
            color: var(--text-color);
            -webkit-font-smoothing: antialiased;
        }}
        h1, h2, h3, h4, h5, h6 {{
            margin-top: 24px;
            margin-bottom: 16px;
            font-weight: 600;
            line-height: 1.25;
            color: var(--h1-color);
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 0.3em;
        }}
        a {{ color: var(--link-color); text-decoration: none; }}
        a:hover {{ text-decoration: underline; }}
        code {{
            padding: 0.2em 0.4em;
            margin: 0;
            font-size: 85%;
            background-color: var(--code-bg);
            border-radius: 6px;
            font-family: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, Liberation Mono, monospace;
        }}
        pre {{
            margin-top: 0;
            margin-bottom: 16px;
            padding: 16px;
            overflow: auto;
            font-size: 85%;
            line-height: 1.45;
            background-color: var(--code-bg);
            border-radius: 6px;
        }}
        pre code {{
            background-color: transparent;
            padding: 0;
        }}
        blockquote {{
            padding: 0 1em;
            color: var(--blockquote-color);
            border-left: 0.25em solid var(--border-color);
            margin: 0 0 16px 0;
        }}
        table {{
            border-spacing: 0;
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 16px;
        }}
        table th, table td {{
            padding: 6px 13px;
            border: 1px solid var(--border-color);
        }}
        table tr {{ background-color: var(--bg-color); border-top: 1px solid var(--border-color); }}
        table tr:nth-child(2n) {{ background-color: var(--code-bg); }}

        .truncation-warning {{
            background-color: #fff3cd;
            color: #856404;
            padding: 12px;
            text-align: center;
            border-radius: 6px;
            margin-bottom: 24px;
            font-size: 14px;
            font-weight: 500;
            border: 1px solid #ffeeba;
        }}
        @media (prefers-color-scheme: dark) {{
            .truncation-warning {{
                background-color: #443c22;
                color: #e6dbb9;
                border-color: #665c33;
            }}
        }}

        /* Fix for syntect output to respect dark mode if needed, 
           but InspiredGitHub is usually light. For dark mode, 
           we would ideally pick a dark theme. */
        pre[style] {{
            filter: var(--code-filter, none);
        }}
        @media (prefers-color-scheme: dark) {{
            :root {{
                --code-filter: invert(0.9) hue-rotate(180deg);
            }}
        }}
    </style>
</head>
<body>
    {}
    <div class="markdown-body">
        {}
    </div>
</body>
</html>"#,
        if is_truncated { "<div class=\"truncation-warning\">⚠️ Preview truncated for performance (Large File)</div>" } else { "" },
        html_output
    );

    let c_string = CString::new(final_html).unwrap();
    c_string.into_raw()
}

#[no_mangle]
pub extern "C" fn mdpreviewer_free_string(ptr: *mut c_char) {
    if ptr.is_null() {
        return;
    }
    unsafe {
        drop(CString::from_raw(ptr));
    }
}
