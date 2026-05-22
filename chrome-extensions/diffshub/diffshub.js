// ==UserScript==
// @name         GitHub PR → DiffsHub
// @namespace    https://diffshub.com/
// @version      1.1.0
// @description  Adds a DiffsHub tab (and Shift+D shortcut) on GitHub pull requests to open the same URL on diffshub.com
// @author       you
// @match        https://github.com/*/*/pull/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=diffshub.com
// @run-at       document-idle
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    const TAB_ID = 'diffshub-tab';
    const IS_PR = () => /^\/[^/]+\/[^/]+\/pull\/\d+/.test(location.pathname);

    const toDiffshub = () => {
        const u = new URL(location.href);
        u.hostname = 'diffshub.com';
        return u.toString();
    };

    // Wait for an element matching `selector` to appear, up to `timeout` ms.
    const waitFor = (selector, { timeout = 15000, root = document } = {}) =>
        new Promise((resolve) => {
            const found = root.querySelector(selector);
            if (found) return resolve(found);

            const obs = new MutationObserver(() => {
                const el = root.querySelector(selector);
                if (el) {
                    obs.disconnect();
                    resolve(el);
                }
            });
            obs.observe(root.body || root, { childList: true, subtree: true });

            if (timeout > 0) {
                setTimeout(() => {
                    obs.disconnect();
                    resolve(null);
                }, timeout);
            }
        });

    const buildTab = (templateTab) => {
        const a = document.createElement('a');
        a.id = TAB_ID;
        a.href = toDiffshub();
        a.target = '_blank';
        a.rel = 'noopener noreferrer';
        a.setAttribute('role', 'tab');
        a.setAttribute('tabindex', '-1');
        a.title = 'Open this PR on diffshub.com (Shift+D)';

        // Clone classes from a sibling tab so styling matches even when hashed names change.
        if (templateTab) a.className = templateTab.className.replace(/\bselected\b|\bprc-TabNav-Selected-[^\s]+/g, '').trim();

        a.innerHTML = `
            <svg aria-hidden="true" focusable="false" class="octicon fg-muted mr-2 d-none d-sm-inline-block"
                 viewBox="0 0 16 16" width="16" height="16" fill="currentColor"
                 style="vertical-align: text-bottom;">
                <path d="M8 0a8 8 0 1 0 0 16A8 8 0 0 0 8 0Zm0 1.5a6.5 6.5 0 1 1 0 13 6.5 6.5 0 0 1 0-13Zm-.75 3a.75.75 0 0 1 1.5 0V8h2.75a.75.75 0 0 1 0 1.5H8.75v2.75a.75.75 0 0 1-1.5 0V9.5H4.5a.75.75 0 0 1 0-1.5h2.75Z"/>
            </svg>DiffsHub`;
        return a;
    };

    const inject = async () => {
        if (!IS_PR()) return;

        const tablist = await waitFor('nav[aria-label="Pull request navigation tabs"] [role="tablist"]');
        if (!tablist) return;

        const existing = document.getElementById(TAB_ID);
        if (existing) {
            existing.href = toDiffshub();
            return;
        }

        const sibling = tablist.querySelector('a[role="tab"]');
        tablist.appendChild(buildTab(sibling));
    };

    // Initial attempt
    inject();

    // Re-run on Turbo / pjax / history navigation
    let lastUrl = location.href;
    const onNav = () => {
        if (location.href !== lastUrl) {
            lastUrl = location.href;
            inject();
        }
    };
    document.addEventListener('turbo:load', inject);
    document.addEventListener('turbo:render', inject);
    document.addEventListener('pjax:end', inject);
    window.addEventListener('popstate', onNav);

    // Catch React re-renders that wipe the tab without changing URL
    new MutationObserver(() => {
        if (IS_PR() && !document.getElementById(TAB_ID)) inject();
        onNav();
    }).observe(document.documentElement, { childList: true, subtree: true });

    // Shift+D shortcut
    document.addEventListener('keydown', (e) => {
        if ((e.key !== 'D' && e.key !== 'd') || !e.shiftKey) return;
        if (e.ctrlKey || e.metaKey || e.altKey) return;
        const t = e.target;
        const tag = (t.tagName || '').toLowerCase();
        if (tag === 'input' || tag === 'textarea' || t.isContentEditable) return;
        e.preventDefault();
        window.open(toDiffshub(), '_blank', 'noopener,noreferrer');
    });
})();
