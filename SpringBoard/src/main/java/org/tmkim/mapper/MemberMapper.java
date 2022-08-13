package org.tmkim.mapper;

import org.tmkim.domain.MemberVO;

public interface MemberMapper
{
    public MemberVO read(String userid);
}
