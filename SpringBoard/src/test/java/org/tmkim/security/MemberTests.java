package org.tmkim.security;

import lombok.Setter;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration({"classpath:WEB-INF/spring/*.xml"})
public class MemberTests
{
    @Setter(onMethod_ = @Autowired)
    private PasswordEncoder pwEncoder;

    @Setter(onMethod_ = @Autowired)
    private DataSource ds;

    @Test
    public void testInsertMember()
    {
        String sql = "INSERT INTO tbl_member(userid, userpw, username) VALUES(?,?,?)";

        for (int i = 0; i < 100; i++)
        {
            try(
                    Connection conn = ds.getConnection();
                    PreparedStatement pstmt = conn.prepareStatement(sql);
            )
            {
                pstmt.setString(2, pwEncoder.encode("pw" + i));

                if (i < 80)
                {
                    pstmt.setString(1, "user" + i);
                    pstmt.setString(3, "일반사용자" + i);
                }
                else if (i < 95)
                {
                    pstmt.setString(1, "manager" + i);
                    pstmt.setString(3, "운영자" + i);
                }
                else
                {
                    pstmt.setString(1, "admin" + i);
                    pstmt.setString(3, "관리자" + i);
                }
                pstmt.executeUpdate();
            }
            catch (SQLException e)
            {
                e.printStackTrace();
            }
        }
    }

    @Test
    public void testInsertAuth()
    {
        String sql = "INSERT INTO tbl_member_auth (userid, auth) values (?,?)";

        for (int i = 0; i < 100; i++)
        {
            try(
                    Connection conn = ds.getConnection();
                    PreparedStatement pstmt = conn.prepareStatement(sql);
            )
            {
                if (i < 80)
                {
                    pstmt.setString(1, "user" + i);
                    pstmt.setString(2, "ROLE_USER");
                }
                else if (i < 95)
                {
                    pstmt.setString(1, "manager" + i);
                    pstmt.setString(2, "ROLE_MANAGER");
                }
                else
                {
                    pstmt.setString(1, "admin" + i);
                    pstmt.setString(2, "ROLE_ADMIN");
                }
                pstmt.executeUpdate();
            }
            catch (SQLException e)
            {
                e.printStackTrace();
            }
        }
    }

}
