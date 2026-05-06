DELIMITER //

CREATE PROCEDURE FindAvailableBed(
    IN p_dept_id INT,
    OUT p_bed_id INT
)
BEGIN
    SELECT bed_id INTO p_bed_id
    FROM Beds
    WHERE dept_id = p_dept_id
      AND status = 'Available'
    LIMIT 1;
END //

DELIMITER ;