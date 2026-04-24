def call_gemini(api_endpoint, params, max_retries=12, initial_delay=30, max_delay=600):
    retry_attempts = 0
    backoff_delay = initial_delay
    while retry_attempts < max_retries:
        response = requests.get(api_endpoint, params=params)
        if response.status_code == 200:
            return response.json()
        elif response.status_code == 503:
            retry_attempts += 1
            time.sleep(backoff_delay)
            backoff_delay = min(backoff_delay * 2, max_delay)  # Exponential backoff
        else:
            response.raise_for_status()
    raise Exception('Max retries exceeded')

# Example usage:
# try:
#     result = call_gemini('https://api.gemini.com/v1/some_endpoint', params)
# except Exception as e:
#     print(e)
