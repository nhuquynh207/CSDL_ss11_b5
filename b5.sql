DELIMITER $$

CREATE PROCEDURE FindAvailableBed(
    IN p_dept_id INT,
    OUT p_bed_id INT
)

BEGIN

    SELECT bed_id
    INTO p_bed_id
    FROM Beds
    WHERE dept_id = p_dept_id
      AND patient_id IS NULL
    LIMIT 1;

END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE TransferPatientBed(
    IN p_patient_id INT,
    IN p_dept_id INT,
    OUT p_new_bed_id INT,
    OUT p_message VARCHAR(255)
)

BEGIN

    DECLARE v_old_bed_id INT;
    DECLARE v_dept_name VARCHAR(100);
    DECLARE v_completed_count INT;

    SELECT COUNT(*)
    INTO v_completed_count
    FROM Appointments
    WHERE patient_id = p_patient_id
      AND status = 'Completed';

    IF v_completed_count > 0 THEN

        SET p_new_bed_id = NULL;
        SET p_message = 'Tu choi: Benh nhan da xuat vien';

    ELSE

        SELECT dept_name
        INTO v_dept_name
        FROM Departments
        WHERE dept_id = p_dept_id;

        IF v_dept_name IS NULL THEN

            SET p_new_bed_id = NULL;
            SET p_message = 'Dept_ID khong ton tai';

        ELSE

            IF p_new_bed_id IS NULL THEN

                SET p_message = CONCAT(
                    'Tu choi: Khoa ',
                    v_dept_name,
                    ' da het giuong'
                );

            ELSE

                SELECT bed_id
                INTO v_old_bed_id
                FROM Beds
                WHERE patient_id = p_patient_id;


                UPDATE Beds
                SET patient_id = NULL
                WHERE bed_id = v_old_bed_id;

                UPDATE Beds
                SET patient_id = p_patient_id
                WHERE bed_id = p_new_bed_id;

                COMMIT;

                SET p_message = 'Chuyen giuong thanh cong';

            END IF;

        END IF;

    END IF;

END $$

DELIMITER ;

-- Kiểm thử
-- (1) Chuyển khoa thành công
CALL TransferPatientBed(1, 2, @bed, @msg);
SELECT @bed, @msg;
-- (2) Khoa hết giường
CALL TransferPatientBed(1, 3, @bed, @msg);

SELECT @bed, @msg;
-- (3) Bệnh nhân đã xuất viện
CALL TransferPatientBed(2, 2, @bed, @msg);
SELECT @bed, @msg;


-- (4) Dept_ID không tồn tại
CALL TransferPatientBed(1, 999, @bed, @msg);
SELECT @bed, @msg;