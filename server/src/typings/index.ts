export interface Dict<TValue> {
	[key: string]: TValue;
}

export class ServerError extends Error {
	public status: number;

	constructor(message: string, status: number) {
		super(message);
		this.status = status;
		Error.captureStackTrace(this, ServerError);
	}
}
