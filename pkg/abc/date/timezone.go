package date

import (
	"fmt"
	"time"
)

// ConvertUtcToTimeZone transforms a UTC date into a different timezone.
func ConvertUtcToTimeZone(utc string, targetTimeZone string) (*time.Time, error) {
	if len(utc) == 0 {
		return nil, fmt.Errorf("the utc datetime cannot be an empty string")
	}

	if len(targetTimeZone) == 0 {
		return nil, fmt.Errorf("the timezone cannot be an empty string")
	}

	if location, err := time.LoadLocation(targetTimeZone); err == nil {
		if t, err := time.Parse(time.RFC3339, utc); err == nil {
			//.ParseInLocation(time.RFC3339, utc, location); err == nil {
			r := t.In(location)
			return &r, nil
		} else {
			return nil, fmt.Errorf("failed to parse and convert the UTC date '%s' to the target timezone of '%s', %w", utc, targetTimeZone, err)
		}
	} else {
		return nil, fmt.Errorf("failed to load the timezone information for '%s', %w", targetTimeZone, err)
	}
}
