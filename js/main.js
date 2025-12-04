/**
 * 乒乓器材网 - 主JavaScript文件
 */

document.addEventListener('DOMContentLoaded', function() {
    // 移动端菜单切换
    initMobileMenu();
    
    // 分类标签切换
    initCategoryTabs();
    
    // 平滑滚动
    initSmoothScroll();
    
    // 导航栏高亮
    updateActiveNav();
});

/**
 * 移动端菜单功能
 */
function initMobileMenu() {
    const menuBtn = document.querySelector('.mobile-menu-btn');
    const navLinks = document.querySelector('.nav-links');
    
    if (menuBtn && navLinks) {
        menuBtn.addEventListener('click', function() {
            navLinks.classList.toggle('active');
            
            // 动画效果
            const spans = menuBtn.querySelectorAll('span');
            spans.forEach((span, index) => {
                span.style.transform = navLinks.classList.contains('active') 
                    ? (index === 1 ? 'scaleX(0)' : `rotate(${index === 0 ? 45 : -45}deg) translateY(${index === 0 ? 8 : -8}px)`)
                    : '';
            });
        });
        
        // 点击链接后关闭菜单
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', function() {
                navLinks.classList.remove('active');
                const spans = menuBtn.querySelectorAll('span');
                spans.forEach(span => span.style.transform = '');
            });
        });
    }
}

/**
 * 分类标签切换功能
 */
function initCategoryTabs() {
    const tabs = document.querySelectorAll('.category-tab');
    const products = document.querySelectorAll('.product-card');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', function() {
            // 更新激活状态
            tabs.forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            
            // 过滤产品
            const category = this.dataset.category;
            
            products.forEach(product => {
                if (category === 'all' || product.dataset.category === category) {
                    product.style.display = 'block';
                    product.style.animation = 'fadeIn 0.5s ease';
                } else {
                    product.style.display = 'none';
                }
            });
        });
    });
}

/**
 * 平滑滚动到锚点
 */
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href !== '#') {
                e.preventDefault();
                const target = document.querySelector(href);
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            }
        });
    });
}

/**
 * 根据当前页面更新导航栏高亮
 */
function updateActiveNav() {
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';
    const navLinks = document.querySelectorAll('.nav-links a');
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        const href = link.getAttribute('href');
        if (href === currentPage || (currentPage === '' && href === 'index.html')) {
            link.classList.add('active');
        }
    });
}

// 添加CSS动画
const style = document.createElement('style');
style.textContent = `
    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);
