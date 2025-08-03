customElements.define('spinner', class extends HTMLElement {
	constructor() {
		super();
		this.frame = 0;
		this.types = {
			'default': ['-', '\\', '|', '/'],
			'circle': ['⢎⡰', '⢎⡡', '⢎⡑', '⢎⠱', '⠎⡱', '⢊⡱', '⢌⡱', '⢆⡱'],
			'circles': ['◐', '◓', '◑', '◒'],
			'blink': ['▊', ' ']
		};
	}

	connectedCallback() {
		const type = this.getAttribute('type') || 'default';
		const rate = parseInt(this.getAttribute('rate') || this.getAttribute('timerate') || 150);
		const duration = parseInt(this.getAttribute('duration') || 0);
		const frames = this.types[type] || this.types['default'];

		this.interval = setInterval(() => {
			this.textContent = frames[this.frame];
			this.frame = (this.frame + 1) % frames.length;
		}, rate);

		if (duration > 0) {
			this.timeout = setTimeout(() => {
				clearInterval(this.interval);
				this.remove();
			}, duration);
		}
	}

	disconnectedCallback() {
		clearInterval(this.interval);
		if (this.timeout) clearTimeout(this.timeout);
	}
});
