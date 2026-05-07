DELIMITER //

-- tìm giường trống
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

DELIMITER //

-- chuyển giupong
CREATE PROCEDURE TransferPatientBed(
    IN p_patient_id INT,
    IN p_dept_id INT,
    OUT p_new_bed_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_old_bed INT;
    DECLARE v_dept_name VARCHAR(100);

    SELECT status, bed_id INTO v_status, v_old_bed
    FROM Patients
    WHERE patient_id = p_patient_id;

    IF v_status IS NULL THEN
        SET p_message = 'Patient not found';
        SET p_new_bed_id = NULL;

    ELSEIF v_status = 'Completed' THEN
        SET p_message = 'Tu choi: Benh nhan da xuat vien';
        SET p_new_bed_id = NULL;

    ELSE

        SELECT dept_name INTO v_dept_name
        FROM Departments
        WHERE dept_id = p_dept_id;

        IF v_dept_name IS NULL THEN
            SET p_message = 'Dept not found';
            SET p_new_bed_id = NULL;

        ELSE

            IF p_new_bed_id IS NULL THEN
                SET p_message = CONCAT('Tu choi: Khoa ', v_dept_name, ' da het giuong');

            ELSE
                START TRANSACTION;

                UPDATE Beds
                SET status = 'Available'
                WHERE bed_id = v_old_bed;

                UPDATE Patients
                SET bed_id = p_new_bed_id
                WHERE patient_id = p_patient_id;


                UPDATE Beds
                SET status = 'Occupied'
                WHERE bed_id = p_new_bed_id;

                COMMIT;

                SET p_message = 'Chuyen giuong thanh cong';
            END IF;
        END IF;
    END IF;

END //

DELIMITER ;

-- Kiểm thử
-- chuyển thành công
CALL TransferPatientBed(1, 2, @bed, @msg);
SELECT @bed, @msg;

-- Hết giường

CALL TransferPatientBed(1, 99, @bed, @msg);
SELECT @bed, @msg;

-- Bệnh nhân đã xuất viện

CALL TransferPatientBed(5, 2, @bed, @msg);
SELECT @bed, @msg;

-- Dept không tồn tại

CALL TransferPatientBed(1, 999, @bed, @msg);
SELECT @bed, @msg;