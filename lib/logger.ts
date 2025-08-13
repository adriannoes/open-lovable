import pino, { Logger, LoggerOptions } from 'pino';

// Detect runtime environment
const isProduction = process.env.NODE_ENV === 'production';
const isTest = process.env.NODE_ENV === 'test';

// Configure redaction of sensitive fields
const redactionPaths = [
	'config.*.apiKey',
	'config.*.token',
	'headers.authorization',
	'authorization',
	'apiKey',
	'token',
];

const baseOptions: LoggerOptions = {
	level: process.env.LOG_LEVEL || (isProduction ? 'info' : 'debug'),
	redact: {
		paths: redactionPaths,
		censor: '[REDACTED]'
	},
	base: {
		service: 'open-lovable',
		environment: process.env.NODE_ENV || 'development',
	},
};

// Pretty transport for local development
const transport = !isProduction && !isTest
	? {
		target: 'pino-pretty',
		options: {
			colorize: true,
			translateTime: 'SYS:standard',
			singleLine: true,
			ignore: 'pid,hostname'
		}
	}
	: undefined;

const logger: Logger = pino({
	...baseOptions,
	transport,
});

export { logger };


