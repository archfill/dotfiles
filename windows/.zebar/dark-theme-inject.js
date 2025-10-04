// Dark theme injection script for paix widget
// This script automatically applies dark theme styling to the paix widget

(function() {
    'use strict';

    function applyDarkTheme() {
        // Apply dark background
        document.body.style.background = 'rgba(20, 20, 20, 0.95)';
        document.body.style.backdropFilter = 'blur(10px)';
        document.body.style.border = '1px solid rgba(255, 255, 255, 0.1)';
        document.body.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.3)';
        document.body.style.borderRadius = '8px';

        // Enhance text visibility
        document.body.style.color = '#ffffff';

        // Style any buttons or interactive elements
        const buttons = document.querySelectorAll('button, .button, [role="button"]');
        buttons.forEach(btn => {
            btn.style.background = 'rgba(255, 255, 255, 0.1)';
            btn.style.border = '1px solid rgba(255, 255, 255, 0.2)';
            btn.style.color = '#ffffff';
            btn.style.borderRadius = '4px';
            btn.style.transition = 'all 0.2s ease';
        });

        // Style workspace indicators
        const workspaces = document.querySelectorAll('.workspace, [class*="workspace"]');
        workspaces.forEach(ws => {
            ws.style.background = 'rgba(255, 255, 255, 0.1)';
            ws.style.borderRadius = '4px';
            ws.style.padding = '4px 8px';
            ws.style.margin = '0 2px';
        });

        console.log('Dark theme applied to paix widget');
    }

    // Apply theme when DOM is loaded
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', applyDarkTheme);
    } else {
        applyDarkTheme();
    }

    // Re-apply theme periodically in case of dynamic content
    setInterval(applyDarkTheme, 5000);
})();