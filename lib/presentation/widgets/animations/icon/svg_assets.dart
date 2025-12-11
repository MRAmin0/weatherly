// lib/widgets/animations/svg_assets.dart

// خورشید (برای چرخش)
const String sunSvg = '''
<svg width="64" height="64" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
    <g transform="scale(0.9) translate(3.5, 3.5)">
        <g transform="translate(32, 32) scale(0.6) translate(-32, -32)">
            <circle cx="32" cy="32" r="12" fill="#FFD700"/>
            <g stroke="#FFD700" stroke-width="4" stroke-linecap="round">
                <path d="M32 2V8"/>
                <path d="M32 56V62"/>
                <path d="M2 32H8"/>
                <path d="M56 32H62"/>
                <path d="M10.8 10.8L15 15"/>
                <path d="M49 49L53.2 53.2"/>
                <path d="M10.8 53.2L15 49"/>
                <path d="M49 15L53.2 10.8"/>
            </g>
        </g>
    </g>
</svg>
''';

// ابر (ثابت)
const String cloudSvg = '''
<svg width="64" height="64" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
    <g transform="scale(0.9) translate(3.5, 3.5)">
        <path
            d="M44 48C44 50.2 42.2 52 40 52H22C18.7 52 16 49.3 16 46C16 43.2 17.9 40.8 20.5 40.2C21.1 36.7 24.1 34 27.8 34C31.5 34 34.7 36.4 35.6 40C35.9 40 36.1 40 36.4 40C38.4 40 40 41.6 40 43.6C40 43.9 40 44.1 39.9 44.4C42.2 44.9 44 46.9 44 48Z"
            fill="#FFFFFF"
            opacity="0.85"
            transform="translate(-8, -12) scale(1.5)"
        />
    </g>
</svg>
''';

// قطره (برای بارش)
const String dropSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path
        d="M12 2C12 2 7 9 7 13C7 15.7614 9.23858 18 12 18C14.7614 18 17 15.7614 17 13C17 9 12 2 12 2Z"
        fill="#40C4FF"
    />
</svg>
''';
